"""empty message

Revision ID: 6d3027e07dc4
Revises: 11c15698c8bf
Create Date: 2022-05-18 19:53:39.773740

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6d3027e07dc4'
down_revision = '11c15698c8bf'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('category',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=128), nullable=True),
    sa.Column('default', sa.Boolean(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.Column('updated_at', sa.DateTime(), nullable=False),
    sa.PrimaryKeyConstraint('id', name=op.f('pk_category'))
    )
    with op.batch_alter_table('item', schema=None) as batch_op:
        batch_op.add_column(sa.Column('category_id', sa.Integer(), nullable=True))
        batch_op.add_column(sa.Column('default', sa.Boolean(), nullable=True))
        batch_op.create_foreign_key(batch_op.f('fk_item_category_id_category'), 'category', ['category_id'], ['id'])

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('item', schema=None) as batch_op:
        batch_op.drop_constraint(batch_op.f('fk_item_category_id_category'), type_='foreignkey')
        batch_op.drop_column('default')
        batch_op.drop_column('category_id')

    op.drop_table('category')
    # ### end Alembic commands ###